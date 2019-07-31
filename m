Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF97BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93D0320C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="afbMm0Gf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93D0320C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0BB48E0027; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEDDD8E0022; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD36F8E0022; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9DA8E0027
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f19so42620207edv.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rS7n4vbFz7RKbnJIWYLJ3LD2/VhASWWBXDQ1YiyXUK4=;
        b=bTR6K1YuJSvcIw55nF+x7OngsYbrbZiFjNqOF2PM7HLbYt3c/bTlONub7lUYZnov7V
         8hzJizcgg3bRg5qjfC2M5uRJW2n2Yn6mtDvNSKTnCb2wOXdeUdKeARi6Phmgv9sTBAD8
         nMtAnGwf0QqBIiWo7hk6Y1qpC7H3I6M0TbH2Z0I85HuEyU7ADTvCk3hQObKKbdC+2N8K
         IQoDsbMmTGYIXkpKMYq0w0nPdPG+sDmjdUtcHL6RREhFX7LNyzT35bkYy6ngHrDyPKhI
         wkJs/XEpEHyPSOq2iqGwDp9s3A/jXuC5UJi97jSEjSUjQfl0xKEO2q7wRnw2QkRDVEXH
         WlWA==
X-Gm-Message-State: APjAAAXB64I8SDZoNxEaHLh+Au6cUjRAZ0N/9vtZvp2f2/7MXaxCLDlM
	1VjvuLiLK2DVednHHhhqmAdIlYIzSxMjd6rMsNASmN4KRa4Nf64H8orQWVQztehKKT8XY7DcilN
	cMHELKYCZfsjfJQgCGR2O3XTUTjUbti7BK+DOTivX1grB7GKNlcA3KFTDJd7/sbw=
X-Received: by 2002:a50:8825:: with SMTP id b34mr107697156edb.22.1564586033738;
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
X-Received: by 2002:a50:8825:: with SMTP id b34mr107697065edb.22.1564586032821;
        Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586032; cv=none;
        d=google.com; s=arc-20160816;
        b=G/zeOsj+cA8tBJIaBVWqhlEaKkz/qoxzZiJHLe0VcViVt8OCyP+Ruvb8kFpXojQSJ8
         Uq6v80SfJnR7L6wQ2MwPWZDQyJq0enBddA0qTGxkqdCGAnuu+BUzsiMPusUz/TWVe/1X
         Ldiwn6CWVuOIKtDqyubMsKVWME1kl8tJvrSIWeLUMHzh3YYNhUIvbSLRA2GD1eye9E0p
         jxXoEySD6hasDhw1R/mmxW7qZunmTa3JByuSfVxGAYxlv1lVoTLMVTmS8iCJ41oq2Gm3
         +hXgRrLn2OAVersNy/FQYi8eSqOrTSplUo9qmz8hfvxE7MhcdrdagkbqlA0PoYy/9a1q
         X0Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rS7n4vbFz7RKbnJIWYLJ3LD2/VhASWWBXDQ1YiyXUK4=;
        b=dXxBjbM7Jt9zg1a9UlkfP/mwUzf1G4vSH/AItnhMdTqdChf4S2MbiHC+NQKmKCj/CC
         o213MMPtg6txxibmtmlp/Z7JUbxOkhAo24p1BEYmTCIfpB7nqzWhQ64OS4DrprPdP6jY
         tdmNYkNMhPHErJ1cakPLt/z5KORVLukCAlA622Ql95IBrsL7cmiy4sR/qvaH1Ht5SqeV
         ZEY//IdWYhmGtheGCvWIQSQoLH9Pd0a8RrkOf8faZqMG+SmvoZ480qbi5fEQrAH6rATC
         L1x8PV76A3HQWFROME7cLxvn97zbVJlcMNvHYE35YIgR0kEhBL+3i34H5TVvuvLbXPZ6
         bd/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=afbMm0Gf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s3sor22358058ejd.4.2019.07.31.08.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=afbMm0Gf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rS7n4vbFz7RKbnJIWYLJ3LD2/VhASWWBXDQ1YiyXUK4=;
        b=afbMm0GfaAisY0kxZUpRSnh8R0UIgNbJC7BJabH5D9WD/FNoXqbra0An01CbRBxtGZ
         6HU1X6ERvuzfNqTtDr+HgIFNQrS9uH8mDg4JioI9lUGBcB+JyiVbUiZDn49xnAK2QQn2
         oQ3mhFNgfpG+AUJM6loNdB65enq3rg75smpnnn5r67isH8PNtXlUf6jqP5gfHsQbMQyF
         l59jSDgnvEUi9oWKOkD6rlyjzioaGiCcKXFv5vzlqChSrqbNMbLCeGEwMXmrJepCKBgI
         Uuo0QV/OGqvUg9Jx7SfUQ3NHZ5kkTcCYHyjFw9TFCxaRJlkdceV57/R8dgaSbT3qft98
         VEWg==
X-Google-Smtp-Source: APXvYqzYx7vkfK0pCreTlPXP87r4rm9+sWwDysXJ5rrTYu3XJTTOF6g20uha3nGp0gwYlH89T1Svfw==
X-Received: by 2002:a17:906:6bc4:: with SMTP id t4mr97503471ejs.256.1564586032415;
        Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id 9sm8069757ejw.63.2019.07.31.08.13.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 7337F1048A6; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 54/59] x86/mktme: Overview of Multi-Key Total Memory Encryption
Date: Wed, 31 Jul 2019 18:08:08 +0300
Message-Id: <20190731150813.26289-55-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Provide an overview of MKTME on Intel Platforms.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/index.rst                |  1 +
 Documentation/x86/mktme/index.rst          |  8 +++
 Documentation/x86/mktme/mktme_overview.rst | 57 ++++++++++++++++++++++
 3 files changed, 66 insertions(+)
 create mode 100644 Documentation/x86/mktme/index.rst
 create mode 100644 Documentation/x86/mktme/mktme_overview.rst

diff --git a/Documentation/x86/index.rst b/Documentation/x86/index.rst
index af64c4bb4447..449bb6abeb0e 100644
--- a/Documentation/x86/index.rst
+++ b/Documentation/x86/index.rst
@@ -22,6 +22,7 @@ x86-specific Documentation
    intel_mpx
    intel-iommu
    intel_txt
+   mktme/index
    amd-memory-encryption
    pti
    mds
diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
new file mode 100644
index 000000000000..1614b52dd3e9
--- /dev/null
+++ b/Documentation/x86/mktme/index.rst
@@ -0,0 +1,8 @@
+
+=========================================
+Multi-Key Total Memory Encryption (MKTME)
+=========================================
+
+.. toctree::
+
+   mktme_overview
diff --git a/Documentation/x86/mktme/mktme_overview.rst b/Documentation/x86/mktme/mktme_overview.rst
new file mode 100644
index 000000000000..64c3268a508e
--- /dev/null
+++ b/Documentation/x86/mktme/mktme_overview.rst
@@ -0,0 +1,57 @@
+Overview
+=========
+Multi-Key Total Memory Encryption (MKTME)[1] is a technology that
+allows transparent memory encryption in upcoming Intel platforms.
+It uses a new instruction (PCONFIG) for key setup and selects a
+key for individual pages by repurposing physical address bits in
+the page tables.
+
+Support for MKTME is added to the existing kernel keyring subsystem
+and via a new mprotect_encrypt() system call that can be used by
+applications to encrypt anonymous memory with keys obtained from
+the keyring.
+
+This architecture supports encrypting both normal, volatile DRAM
+and persistent memory.  However, persistent memory support is
+not included in the Linux kernel implementation at this time.
+(We anticipate adding that support next.)
+
+Hardware Background
+===================
+
+MKTME is built on top of an existing single-key technology called
+TME.  TME encrypts all system memory using a single key generated
+by the CPU on every boot of the system. TME provides mitigation
+against physical attacks, such as physically removing a DIMM or
+watching memory bus traffic.
+
+MKTME enables the use of multiple encryption keys[2], allowing
+selection of the encryption key per-page using the page tables.
+Encryption keys are programmed into each memory controller and
+the same set of keys is available to all entities on the system
+with access to that memory (all cores, DMA engines, etc...).
+
+MKTME inherits many of the mitigations against hardware attacks
+from TME.  Like TME, MKTME does not mitigate vulnerable or
+malicious operating systems or virtual machine managers.  MKTME
+offers additional mitigations when compared to TME.
+
+TME and MKTME use the AES encryption algorithm in the AES-XTS
+mode.  This mode, typically used for block-based storage devices,
+takes the physical address of the data into account when
+encrypting each block.  This ensures that the effective key is
+different for each block of memory. Moving encrypted content
+across physical address results in garbage on read, mitigating
+block-relocation attacks.  This property is the reason many of
+the discussed attacks require control of a shared physical page
+to be handed from the victim to the attacker.
+
+--
+1. https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
+2. The MKTME architecture supports up to 16 bits of KeyIDs, so a
+   maximum of 65535 keys on top of the “TME key” at KeyID-0.  The
+   first implementation is expected to support 6 bits, making 63
+   keys available to applications.  However, this is not guaranteed.
+   The number of available keys could be reduced if, for instance,
+   additional physical address space is desired over additional
+   KeyIDs.
-- 
2.21.0

