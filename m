Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 2CA7F6B0008
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 14:44:38 -0500 (EST)
In-Reply-To: <20130211182826.GE2683@pd.tnic>
References: <20130208202813.62965F25@kernel.stglabs.ibm.com> <20130209094121.GB17728@pd.tnic> <20130209104751.GC17728@pd.tnic> <51192B39.9060501@linux.vnet.ibm.com> <20130211182826.GE2683@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 1/2] add helper for highmem checks
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Mon, 11 Feb 2013 11:44:12 -0800
Message-ID: <7794bbcd-5d5a-4e81-87fd-68b0aa17a556@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de

Oh, craptastic.  X used to hash /dev/mem to get a random seed.  It should have stopped that long ago, and used /dev/[u]random.

Borislav Petkov <bp@alien8.de> wrote:

>On Mon, Feb 11, 2013 at 09:32:41AM -0800, Dave Hansen wrote:
>> That's crazy. Didn't expect that at all.
>>
>> I guess X is happier getting an error than getting random pages back.
>
>Yeah, I think this is something special only this window manager wdm
>does. The line below has appeared repeatedly in the logs earlier:
>
>Feb  5 23:02:02 a1 wdm: Cannot read randomFile "/dev/mem", errno = 14
>
>This happens when wdm starts so I'm going to guess it uses it for
>something funny, "randomFile" it calls it??
>
>With the WARN_ON check added and booting 3.8-rc6, it would choke wdm
>somehow and it wouldn't start properly so that even the error out above
>doesn't happen. Oh well ...
>
>> I'm working on a set of patches now that should get it _working_
>> instead of just returning an error.
>
>Yeah, send them on and I'll run them.
>
>Thanks.

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
