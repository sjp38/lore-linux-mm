Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCB86B0037
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 20:10:06 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so6391177pde.41
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:10:06 -0800 (PST)
Received: from smtp.mozilla.org (mx2.corp.phx1.mozilla.com. [63.245.216.70])
        by mx.google.com with ESMTP id sz7si13257883pab.319.2014.01.27.17.10.04
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 17:10:05 -0800 (PST)
Message-ID: <52E70367.1080504@mozilla.com>
Date: Mon, 27 Jan 2014 17:09:59 -0800
From: Taras Glek <tglek@mozilla.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
References: <1388646744-15608-1-git-send-email-minchan@kernel.org> <CAHGf_=qiQtG_7W=SfKfGHgV6p6aT3==Wnj65UAegejeoS6fLBA@mail.gmail.com> <20140128001244.GB25066@bbox> <52E6FCF3.6010009@linaro.org>
In-Reply-To: <52E6FCF3.6010009@linaro.org>
Content-Type: multipart/alternative;
 boundary="------------080601060906010006060403"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

This is a multi-part message in MIME format.
--------------080601060906010006060403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



John Stultz wrote:
> On 01/27/2014 04:12 PM, Minchan Kim wrote:
>> On Mon, Jan 27, 2014 at 05:23:17PM -0500, KOSAKI Motohiro wrote:
>>> - Your number only claimed the effectiveness anon vrange, but not file vrange.
>> Yes. It's really problem as I said.
>>  From the beginning, John Stultz wanted to promote vrange-file to replace
>> android's ashmem and when I heard usecase of vrange-file, it does make sense
>> to me so that's why I'd like to unify them in a same interface.
>>
>> But the problem is lack of interesting from others and lack of time to
>> test/evaluate it. I'm not an expert of userspace so actually I need a bit
>> help from them who require the feature but at a moment,
>> but I don't know who really want or/and help it.
>>
>> Even, Android folks didn't have any interest on vrange-file.
>
> Just as a correction here. I really don't think this is the case, as
> Android's use definitely relies on file based volatility. It might be
> more fair to say there hasn't been very much discussion from Android
> developers on the particulars of the file volatility semantics (out
> possibly not having any particular objections, or more-likely, being a
> bit too busy to follow the all various theoretical tangents we've
> discussed).
>
> But I'd not want anyone to get the impression that anonymous-only
> volatility would be sufficient for Android's needs.
Mozilla is starting to use android's ashmem for discardable memory 
within a single process: 
https://bugzilla.mozilla.org/show_bug.cgi?id=748598 .

Volatile ranges do help with that specific(uncommon?) use of ashmem.

For Mozilla sharing memory across processes via ashmem is not a nearterm 
project. It's something that is likely to require significant rework. 
Process-local discardable memory can be retrofited in a more 
straight-forward fashion.

Taras

--------------080601060906010006060403
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html><head>
<meta content="text/html; charset=ISO-8859-1" http-equiv="Content-Type">
</head><body bgcolor="#FFFFFF" text="#000000"><br>
<br>
John Stultz wrote:
<blockquote cite="mid:52E6FCF3.6010009@linaro.org" type="cite">
  <pre wrap="">On 01/27/2014 04:12 PM, Minchan Kim wrote:
</pre>
  <blockquote type="cite"><pre wrap="">On Mon, Jan 27, 2014 at 05:23:17PM -0500, KOSAKI Motohiro wrote:
</pre><blockquote type="cite"><pre wrap="">- Your number only claimed the effectiveness anon vrange, but not file vrange.
</pre></blockquote><pre wrap="">Yes. It's really problem as I said.
>From the beginning, John Stultz wanted to promote vrange-file to replace
android's ashmem and when I heard usecase of vrange-file, it does make sense
to me so that's why I'd like to unify them in a same interface.

But the problem is lack of interesting from others and lack of time to
test/evaluate it. I'm not an expert of userspace so actually I need a bit
help from them who require the feature but at a moment,
but I don't know who really want or/and help it.

Even, Android folks didn't have any interest on vrange-file.
</pre></blockquote>
  <pre wrap=""><!---->
Just as a correction here. I really don't think this is the case, as
Android's use definitely relies on file based volatility. It might be
more fair to say there hasn't been very much discussion from Android
developers on the particulars of the file volatility semantics (out
possibly not having any particular objections, or more-likely, being a
bit too busy to follow the all various theoretical tangents we've
discussed).

But I'd not want anyone to get the impression that anonymous-only
volatility would be sufficient for Android's needs.</pre>
</blockquote>
Mozilla is starting to use android's ashmem for discardable memory 
within a single process: 
<a class="moz-txt-link-freetext" href="https://bugzilla.mozilla.org/show_bug.cgi?id=748598">https://bugzilla.mozilla.org/show_bug.cgi?id=748598</a> .<br>
<br>
Volatile ranges do help with that specific(uncommon?) use of ashmem.<br>
<br>
For Mozilla sharing memory across processes via ashmem is not a nearterm
 project. It's something that is likely to require significant rework. 
Process-local discardable memory can be retrofited in a more 
straight-forward fashion. <br>
<br>
Taras<br>
<blockquote cite="mid:52E6FCF3.6010009@linaro.org" type="cite">
  <pre wrap="">
</pre>
</blockquote>
</body></html>

--------------080601060906010006060403--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
