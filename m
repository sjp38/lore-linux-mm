Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F949C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C5E4216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C5E4216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E63776B027A; Wed,  8 May 2019 10:44:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFADE6B0279; Wed,  8 May 2019 10:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A898C6B027A; Wed,  8 May 2019 10:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 688176B0279
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so12804614pgo.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xNB81vjfr29anZNeZJ7zWyFQitPew0Qf2mqnTgj07L4=;
        b=AbvsSkXmDh0tJaASQ8ikz9PTq3ak03a8yGXKXFBWkC3gfzMpgh0n7xdpLpUAY7gP/Z
         023jriZECHckyam083TWXbLUTEGNsWhdPo76jUBJ0Ab2phsDTCf909gPjDUUypSt+H+g
         aOsnHf0wmhTEO6rS4hOsUqVIkmhlpyH/9dCHfCp3PvW5bZSaeWR+yFvFMG81B+nhRz0H
         tXUkwxLzc/y0Fu0WkcyKz7BLn91PhbybWHDcxg/5LXu3v1yWL8B6ziS/m9xQt1MH0Fym
         SN25CGZJsuXBRZzmWq2696YIibGLRMtMivazqsHNxK6XOamxQSohOjkId1KUjXOS15x3
         JdYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUvXgbwVVeLL9W1p914veDwUNukgfSwWgtX4SrKLeVcCNTTCxc6
	MMNfpBXV07ccgnDMtOY+w30isz3mLcU4JlLGyBhwFoedfJLUQ+1ju2gUYioJRSXP3XwqKiiscBp
	5szpU52H5F0zTesZLtcMI/csvTmP+O1HU4++h6hmu1UoYTud+EVhdV0GBBndURmQ1rQ==
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr46493992pgr.72.1557326687066;
        Wed, 08 May 2019 07:44:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjKuBfgISgA/9EVPLSIk4goDF0aLvSidvoizeRzzZWfs/x+gn6KRzHafwlavSdrPmfRVvc
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr46493857pgr.72.1557326685563;
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326685; cv=none;
        d=google.com; s=arc-20160816;
        b=DJSW5hsLJg3zgkzmVQl3fvDmRLavZQZ/iI9Q3InfB4x7rUtUF2uIkr7IN0/TauQOZG
         vvgFMh7TxuU6OrTk7QBZuwzVCUBuHA3Pq6x/5zuTwx2kDTC121v79h4ivfyt8G6NWLuz
         XRtR1ewkH7Beo+1dHmyU9OkIfN4+Uq0tvz/mdqV9nTGI3UkHEys1imLLkYqHDx33Uvru
         CtouSrsqLs2Hc4V/nscA6t+y5CGUFcY2cumnCCbEl/2ngh6W1CjXXbNE6/DoAHyxja3z
         jn2cdkqN2pYNfAFf2yeQnyy0dXlC62UaPmw/8peZI1fVopDUU7ziSnh8TNKPpThW09kA
         sBgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xNB81vjfr29anZNeZJ7zWyFQitPew0Qf2mqnTgj07L4=;
        b=vlNmOfM8qZq2giMTzvooiuKsWT48hhSmfI6Aik2tybta4etPlD4vLHvIKMZIMbiWh5
         lgilAZRhhusMiROW3eXi21lwk43K3hgQPea6XdlNDZafHLfSUYj5F4o1Kh4ILNiUuVPu
         mw3N1HcVkahYi+AozwSXveRP1DI4VdLJ0K6TpKbzWEjQnvk+9Uy+yElXBWXY0wQSlpzD
         LPMWI0b5FayYNXrfPPMstkBcMJhivO1aFFPfMdVyxJPiSJP14sYhJDxDwnjV9+PqGqDn
         EDcr5E1Po7HwpcFQswXiSWyBjyMJISxa7fa/MaQVcmJwBh3mL20aeS7Uxkkc6v5irk/b
         dBhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 184si24250871pfg.32.2019.05.08.07.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:45 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga002.jf.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 1BE06B26; Wed,  8 May 2019 17:44:30 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
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
Subject: [PATCH, RFC 29/62] keys/mktme: Program MKTME keys into the platform hardware
Date: Wed,  8 May 2019 17:43:49 +0300
Message-Id: <20190508144422.13171-30-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Finally, the keys are programmed into the hardware via each
lead CPU. Every package has to be programmed successfully.
There is no partial success allowed here.

Here a retry scheme is included for two errors that may succeed
on retry: MKTME_DEVICE_BUSY and MKTME_ENTROPY_ERROR.
However, it's not clear if even those errors should be retried
at this level. Perhaps they too, should be returned to user space
for handling.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 92 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 91 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index b5b44decfd3e..f70533b1a7fd 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -102,6 +102,96 @@ struct mktme_payload {
 	u8		tweak_key[MKTME_AES_XTS_SIZE];
 };
 
+struct mktme_hw_program_info {
+	struct mktme_key_program *key_program;
+	int *status;
+};
+
+struct mktme_err_table {
+	const char *msg;
+	bool retry;
+};
+
+static const struct mktme_err_table mktme_error[] = {
+/* MKTME_PROG_SUCCESS     */ {"KeyID was successfully programmed",   false},
+/* MKTME_INVALID_PROG_CMD */ {"Invalid KeyID programming command",   false},
+/* MKTME_ENTROPY_ERROR    */ {"Insufficient entropy",		      true},
+/* MKTME_INVALID_KEYID    */ {"KeyID not valid",		     false},
+/* MKTME_INVALID_ENC_ALG  */ {"Invalid encryption algorithm chosen", false},
+/* MKTME_DEVICE_BUSY      */ {"Failure to access key table",	      true},
+};
+
+static int mktme_parse_program_status(int status[])
+{
+	int cpu, sum = 0;
+
+	/* Success: all CPU(s) programmed all key table(s) */
+	for_each_cpu(cpu, mktme_leadcpus)
+		sum += status[cpu];
+	if (!sum)
+		return MKTME_PROG_SUCCESS;
+
+	/* Invalid Parameters: log the error and return the error. */
+	for_each_cpu(cpu, mktme_leadcpus) {
+		switch (status[cpu]) {
+		case MKTME_INVALID_KEYID:
+		case MKTME_INVALID_PROG_CMD:
+		case MKTME_INVALID_ENC_ALG:
+			pr_err("mktme: %s\n", mktme_error[status[cpu]].msg);
+			return status[cpu];
+
+		default:
+			break;
+		}
+	}
+	/*
+	 * Device Busy or Insufficient Entropy: do not log the
+	 * error. These will be retried and if retries (time or
+	 * count runs out) caller will log the error.
+	 */
+	for_each_cpu(cpu, mktme_leadcpus) {
+		if (status[cpu] == MKTME_DEVICE_BUSY)
+			return status[cpu];
+	}
+	return MKTME_ENTROPY_ERROR;
+}
+
+/* Program a single key using one CPU. */
+static void mktme_do_program(void *hw_program_info)
+{
+	struct mktme_hw_program_info *info = hw_program_info;
+	int cpu;
+
+	cpu = smp_processor_id();
+	info->status[cpu] = mktme_key_program(info->key_program);
+}
+
+static int mktme_program_all_keytables(struct mktme_key_program *key_program)
+{
+	struct mktme_hw_program_info info;
+	int err, retries = 10; /* Maybe users should handle retries */
+
+	info.key_program = key_program;
+	info.status = kcalloc(num_possible_cpus(), sizeof(info.status[0]),
+			      GFP_KERNEL);
+
+	while (retries--) {
+		get_online_cpus();
+		on_each_cpu_mask(mktme_leadcpus, mktme_do_program,
+				 &info, 1);
+		put_online_cpus();
+
+		err = mktme_parse_program_status(info.status);
+		if (!err)			   /* Success */
+			return err;
+		else if (!mktme_error[err].retry)  /* Error no retry */
+			return -ENOKEY;
+	}
+	/* Ran out of retries */
+	pr_err("mktme: %s\n", mktme_error[err].msg);
+	return err;
+}
+
 /* Copy the payload to the HW programming structure and program this KeyID */
 static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 {
@@ -127,7 +217,7 @@ static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
 			kprog->key_field_2[i] ^= kern_entropy[i];
 		}
 	}
-	ret = MKTME_PROG_SUCCESS;	/* Future programming call */
+	ret = mktme_program_all_keytables(kprog);
 	kmem_cache_free(mktme_prog_cache, kprog);
 	return ret;
 }
-- 
2.20.1

