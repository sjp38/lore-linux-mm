Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB0B56B00A7
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 20:58:20 -0500 (EST)
Message-ID: <4B5510B1.9010202@zytor.com>
Date: Mon, 18 Jan 2010 17:53:53 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
References: <1262700774-1808-1-git-send-email-gleb@redhat.com> <1262700774-1808-5-git-send-email-gleb@redhat.com> <1263490267.4244.340.camel@laptop> <20100117144411.GI31692@redhat.com> <4B541D08.9040802@zytor.com> <20100118085022.GA30698@redhat.com>
In-Reply-To: <20100118085022.GA30698@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/18/2010 12:50 AM, Gleb Natapov wrote:
> On Mon, Jan 18, 2010 at 12:34:16AM -0800, H. Peter Anvin wrote:
>> On 01/17/2010 06:44 AM, Gleb Natapov wrote:
>>> On Thu, Jan 14, 2010 at 06:31:07PM +0100, Peter Zijlstra wrote:
>>>> On Tue, 2010-01-05 at 16:12 +0200, Gleb Natapov wrote:
>>>>> Allow paravirtualized guest to do special handling for some page faults.
>>>>>
>>>>> The patch adds one 'if' to do_page_fault() function. The call is patched
>>>>> out when running on physical HW. I ran kernbech on the kernel with and
>>>>> without that additional 'if' and result were rawly the same:
>>>>
>>>> So why not program a different handler address for the #PF/#GP faults
>>>> and avoid the if all together?
>>> I would gladly use fault vector reserved by x86 architecture, but I am
>>> not sure Intel will be happy about it.
>>>
>>
>> That's what it's there for... see Peter Z.'s response.
>>
> Do you mean I can use one of exception vectors reserved by Intel
> (20-31)? What Peter Z says is that I can register my own handler for
> #PF and avoid the 'if' in non PV case as far as I understand him.
> 

What I mean is that vector 14 is page faults -- that's what it is all
about.  Why on Earth do you need another vector?

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
