Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 0A64E6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 22:15:13 -0400 (EDT)
In-Reply-To: <515CDD0A.8040100@gmail.com>
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com> <515B2802.1050405@zytor.com> <515CD359.40004@gmail.com> <515CD3BF.5010104@zytor.com> <515CD4A7.6070903@gmail.com> <515CD81D.6020603@zytor.com> <515CDD0A.8040100@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Wed, 03 Apr 2013 19:14:55 -0700
Message-ID: <6158c206-0861-41c9-84b8-6fec82b8110d@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

Because git didn't exist before then?

Simon Jeons <simon.jeons@gmail.com> wrote:

>On 04/04/2013 09:32 AM, H. Peter Anvin wrote:
>> On 04/03/2013 06:17 PM, Simon Jeons wrote:
>>> e820 also contain mmio, correct?
>> No.
>>
>>> So cpu should not access address beyond
>>> e820 map(RAM+MMIO).
>> No.
>>
>> 	-hpa
>>
>>
>
>One offline question, why can't check git log before 2005?

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
