Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 261196B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 13:42:40 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so5887380pdb.7
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 10:42:39 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ef7si10961217pac.71.2014.10.13.10.42.38
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 10:42:39 -0700 (PDT)
Message-ID: <543C0EBE.3060702@intel.com>
Date: Mon, 13 Oct 2014 10:41:18 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>	<1405921124-4230-9-git-send-email-qiaowei.ren@intel.com> <87lhrn2qfu.fsf@tassilo.jf.intel.com>
In-Reply-To: <87lhrn2qfu.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/20/2014 11:09 PM, Andi Kleen wrote:
> Qiaowei Ren <qiaowei.ren@intel.com> writes:
>> This patch adds the PR_MPX_REGISTER and PR_MPX_UNREGISTER prctl()
>> commands. These commands can be used to register and unregister MPX
>> related resource on the x86 platform.
> 
> Please provide a manpage for the API. This is needed
> for proper review. Your description is far too vague.

Qiaowei, have you written this manpage yet?  I see the new patches, but
no manpage yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
