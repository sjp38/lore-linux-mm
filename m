Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 225BE6B0039
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 14:54:44 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so1283590pdj.7
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 11:54:43 -0700 (PDT)
Message-ID: <524C6BCD.2000007@zytor.com>
Date: Wed, 02 Oct 2013 11:54:05 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH] x86: add phys addr validity check for /dev/mem
 mmap
References: <20131002160514.GA25471@localhost.localdomain> <524C5BFB.5050501@zytor.com> <20131002183155.GA2975@localhost.localdomain> <524C6799.9060800@zytor.com> <20131002184803.GB2975@localhost.localdomain>
In-Reply-To: <20131002184803.GB2975@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com

On 10/02/2013 11:48 AM, Frantisek Hrbata wrote:
> 
> Ok, I can try to look into this. I just want to point out that some other archs
> like arm are doing it the same way. I simply replaced the generic check functions
> in drivers/char/mem.c with x86 specific ones.
> 

I know.  It is a longstanding problem.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
