Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6496B009E
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 20:33:01 -0500 (EST)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n0A1Wv0p018375
	for <linux-mm@kvack.org>; Sat, 10 Jan 2009 01:32:57 GMT
Received: from rv-out-0506.google.com (rvbf6.prod.google.com [10.140.82.6])
	by zps38.corp.google.com with ESMTP id n0A1WsY1012246
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 17:32:55 -0800
Received: by rv-out-0506.google.com with SMTP id f6so10016940rvb.3
        for <linux-mm@kvack.org>; Fri, 09 Jan 2009 17:32:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090109163725.11294fb1.akpm@linux-foundation.org>
References: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
	 <604427e00901081840pa6dcc41u9a7a5c69302c7b60@mail.gmail.com>
	 <604427e00901091627n7c909abt6aa1f01c181ad65d@mail.gmail.com>
	 <20090109163725.11294fb1.akpm@linux-foundation.org>
Date: Fri, 9 Jan 2009 17:32:54 -0800
Message-ID: <604427e00901091732reaef7b5u6ccd89ffb840dbb8@mail.gmail.com>
Subject: Re: [PATCH]Fix: 32bit binary has 64bit address of stack vma
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mikew@google.com, rohitseth@google.com, linux-api@vger.kernel.org, oleg@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, Jan 9, 2009 at 4:37 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 9 Jan 2009 16:27:07 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> friendly ping...
>
> We'll get there.  We're in the merge window now, so I tend to defer
> non-serious bugfixes until things are a bit quieter.
Thank you Andrew .

>
>> On Thu, Jan 8, 2009 at 6:40 PM, Ying Han <yinghan@google.com> wrote:
>> > On Mon, Jan 5, 2009 at 3:39 PM, Ying Han <yinghan@google.com> wrote:
>> >> From: Ying Han <yinghan@google.com>
>> >>
>> >> Fix 32bit binary get 64bit stack vma offset.
>> >>
>> >> 32bit binary running on 64bit system, the /proc/pid/maps shows for the
>> >> vma represents stack get a 64bit adress:
>> >> ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]
>
> That changelog hurts my brain.
hm, i will change it for better reading.
>
>> >> Signed-off-by:  Ying Han <yinghan@google.com>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
