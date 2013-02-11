Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 06FB26B0008
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 13:10:21 -0500 (EST)
Message-ID: <511933F5.9000902@zytor.com>
Date: Mon, 11 Feb 2013 10:09:57 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] add helper for highmem checks
References: <20130208202813.62965F25@kernel.stglabs.ibm.com> <20130209094121.GB17728@pd.tnic> <20130209104751.GC17728@pd.tnic> <51192B39.9060501@linux.vnet.ibm.com>
In-Reply-To: <51192B39.9060501@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de

On 02/11/2013 09:32 AM, Dave Hansen wrote:
> On 02/09/2013 02:47 AM, Borislav Petkov wrote:
>> On Sat, Feb 09, 2013 at 10:41:21AM +0100, Borislav Petkov wrote:
>> With this change, they definitely fix something because I even get X on
>> the box started. Previously, it would spit out the warning and wouldn't
>> start X with the login window. And my suspicion is that wdm (WINGs
>> display manager) I'm using, does /dev/mem accesses when it starts and it
>> obviously failed. Now not so much :-)
>
> That's crazy.  Didn't expect that at all.
>
> I guess X is happier getting an error than getting random pages back.
> I'm working on a set of patches now that should get it _working_ instead
> of just returning an error.
>

Awesome :)

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
