Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B19F7C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:11:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76CEE21773
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:11:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76CEE21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3DD86B0003; Fri, 14 Jun 2019 15:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC71F6B000C; Fri, 14 Jun 2019 15:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C42516B000D; Fri, 14 Jun 2019 15:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9C76B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:11:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l4so2437038pff.5
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=Fl82JVASVXXJHD3w7XRUnCulujcPkRixRekkmHub5PE=;
        b=rMY04Ze3D/df7ZOYSIbtHzygU2PUg5p7t45bEqfzI0Ecd1/9YnEv1LkLpcHpHVdzGh
         ZlISHt5oi63L+Zs1HwlEDVrYgffZk0U1xwFbLGBRZeqvHM1d3KhPxbk/bcPOyyF1WrDS
         8ssQOCoExe+To9ukTv+/CStJNP5BYLmH7MvJriRUnp0DHpC8IApEwAkTrW+p3k07htMs
         GnuE/wqHuCVQqCy5+4DVInPQopnvtMqczDYx1NDHTU/6CT2eQqZwhVf95wnjmnRMMA2i
         96BED7N3+ClnAkuAFgslkvqujcwffCL6HlwV1sps5RUZX64vLorNqLIWMaoLYEHfl6dn
         /t8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU337RAC4syia12bcUcZZDRVjmArB2i5Dr9J1TXSGGV7QEP3ogM
	JavxgojJb+PVn/m3sVEWPc+UqoNNeIYc+2dagQpSWQ9SxeN9ls2gvkINIe0UXzACo+0xLHssPFh
	84YIwOIdepUVAMBozZ+pbCJPIluuWs3SKHVHzw94LRFj/6F7pZbGNHoxjppyDq//u8w==
X-Received: by 2002:aa7:82d7:: with SMTP id f23mr98849160pfn.138.1560539486245;
        Fri, 14 Jun 2019 12:11:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyt39ijONB/dchvv+xdSmOAWojazHfkAbGp/nzyBoHFeiW2yNOBwsUkXMzMSj6/+WiakD9s
X-Received: by 2002:aa7:82d7:: with SMTP id f23mr98849018pfn.138.1560539484496;
        Fri, 14 Jun 2019 12:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560539484; cv=none;
        d=google.com; s=arc-20160816;
        b=f+CdgMh3pPVj5MPoolMyS9Y2xMk8ALSwMfNGJmYE7qrfYVwIHQXe8dA6lbzF+QKUen
         Hes3QOrpkHP0zPC59FmCSj1L7TJARinE7EPQAGhGkibspG+NrAR4RwVloxQz6Ew7878I
         gG0KjpLjSUyPt78yGTHfGW1thgaNZlGOv5I453Qw6TUex27XjtQW+8tFYHrEgCxD8nZz
         qJ/j7LmggQYuXY4527tK/amdfo6Ks0vWMhpt7egGIUYxJCDLARUSP4uYSLVMvl6FSPyu
         3owEIBL1JgIuMnrLPsZDh8LU9sipRhsW+Wl0U6cX0wsGkkDzmHcOfa1Va38AI9aEY4QB
         /8Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=Fl82JVASVXXJHD3w7XRUnCulujcPkRixRekkmHub5PE=;
        b=UhleGvLVjgMDVPHeVUbM9xnTE3n1fyFxbX8ix/cxyoqFntSvwmlk/gQKu7ZHG8hKsV
         7Lw2FgqE1agknG4AqY8/xO52zE7VQ6kZogj2Vhz8PSSDNQW7KxdpuTp9fN32N7Vf+PjQ
         QlO7nXAoQenf+kjz3iwENJoIs5LkT0JBTx64QF0rMS5nrWoihLzUG3X6+l4wWBkInqpR
         rxjSBAMdOCavC0XoNkfCYQBiiimW+u06YBT3Ih852uEVWw3VePDdEUEAoo2+9zigYBJl
         S5l5d1Rq4oh0c+R4N1rrYycBZHxfeSXi8S7krVAZ2V+5cT6yMxzqhAjpPQ6YPCYGQCWQ
         kjnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u71si3265314pgd.455.2019.06.14.12.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 12:11:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 12:11:24 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.15]) ([10.7.201.15])
  by orsmga007.jf.intel.com with ESMTP; 14 Jun 2019 12:11:23 -0700
Subject: Re: [PATCH, RFC 44/62] x86/mm: Set KeyIDs in encrypted VMAs for MKTME
To: Alison Schofield <alison.schofield@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@amacapital.net>, David Howells <dhowells@redhat.com>,
 Kees Cook <keescook@chromium.org>, Kai Huang <kai.huang@linux.intel.com>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
 kvm@vger.kernel.org, keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
 <20190614114408.GD3436@hirez.programming.kicks-ass.net>
 <20190614173345.GB5917@alison-desk.jf.intel.com>
 <e0884a6b-78bc-209d-bc9a-90f69839189e@intel.com>
 <20190614184602.GB7252@alison-desk.jf.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <ca62a921-e60c-6532-32c3-f02e15ba69aa@intel.com>
Date: Fri, 14 Jun 2019 12:11:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614184602.GB7252@alison-desk.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 11:46 AM, Alison Schofield wrote:
> On Fri, Jun 14, 2019 at 11:26:10AM -0700, Dave Hansen wrote:
>> On 6/14/19 10:33 AM, Alison Schofield wrote:
>>> Preserving the data across encryption key changes has not
>>> been a requirement. I'm not clear if it was ever considered
>>> and rejected. I believe that copying in order to preserve
>>> the data was never considered.
>>
>> We could preserve the data pretty easily.  It's just annoying, though.
>> Right now, our only KeyID conversions happen in the page allocator.  If
>> we were to convert in-place, we'd need something along the lines of:
>>
>> 	1. Allocate a scratch page
>> 	2. Unmap target page, or at least make it entirely read-only
>> 	3. Copy plaintext into scratch page
>> 	4. Do cache KeyID conversion of page being converted:
>> 	   Flush caches, change page_ext metadata
>> 	5. Copy plaintext back into target page from scratch area
>> 	6. Re-establish PTEs with new KeyID
> 
> Seems like the 'Copy plaintext' steps might disappoint the user, as
> much as the 'we don't preserve your data' design. Would users be happy
> w the plain text steps ?

Well, it got to be plaintext because they wrote it to memory in
plaintext in the first place, so it's kinda hard to disappoint them. :)

IMNHO, the *vast* majority of cases, folks will allocate memory and then
put a secret in it.  They aren't going to *get* a secret in some
mysterious fashion and then later decide they want to protect it.  In
other words, the inability to convert it is pretty academic and not
worth the complexity.

