From: Keith Owens <kaos@ocs.com.au>
Subject: Re: Kernel BUG at mm/rmap.c:491 
In-reply-to: Your message of "Thu, 24 Nov 2005 07:50:49 -0000."
             <Pine.LNX.4.61.0511240747590.5688@goblin.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Fri, 25 Nov 2005 10:47:41 +1100
Message-ID: <25093.1132876061@ocs3.ocs.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Dave Jones <davej@redhat.com>, Alistair John Strachan <s0348365@sms.ed.ac.uk>, Con Kolivas <con@kolivas.org>, Kenneth W <kenneth.w.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Nov 2005 07:50:49 +0000 (GMT), 
Hugh Dickins <hugh@veritas.com> wrote:
>On Wed, 23 Nov 2005, Dave Jones wrote:
>> On Wed, Nov 23, 2005 at 11:35:15PM +0000, Alistair John Strachan wrote:
>>  > On Wednesday 23 November 2005 23:24, Con Kolivas wrote:
>>  > > Chen, Kenneth W writes:
>>  > > > Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
>>  > > >
>>  > > > Pid: 16500, comm: cc1 Tainted: G    B 2.6.15-rc2 #3
>>  > > >
>>  > > > Pid: 16651, comm: sh Tainted: G    B 2.6.15-rc2 #3
>>  > >
>>  > >                        ^^^^^^^^^^
>>  > >
>>  > > Please try to reproduce it without proprietary binary modules linked in.
>>  > 
>>  > AFAIK "G" means all loaded modules are GPL, P is for proprietary modules.
>> 
>> The 'G' seems to confuse a hell of a lot of people.
>> (I've been asked about it when people got machine checks a lot over
>>  the last few months).
>> 
>> Would anyone object to changing it to conform to the style of
>> the other taint flags ? Ie, change it to ' ' ?
>
>Please, please do: it's insane as is.  But I've CC'ed Keith,
>we sometimes find the kernel does things so to suit ksymoops.

'G' is not one of mine, I find it annoying as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
