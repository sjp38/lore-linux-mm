Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A87816B002B
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 12:20:39 -0500 (EST)
Received: by mail-la0-f73.google.com with SMTP id b11so125097lam.2
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 09:20:37 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
References: <20121107105348.GA25549@lizard>
	<20121107112136.GA31715@shutemov.name>
Date: Wed, 07 Nov 2012 09:20:35 -0800
In-Reply-To: <20121107112136.GA31715@shutemov.name> (Kirill A. Shutemov's
	message of "Wed, 7 Nov 2012 13:21:36 +0200")
Message-ID: <xr93liedfhy4.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, Nov 07 2012, Kirill A. Shutemov wrote:

> On Wed, Nov 07, 2012 at 02:53:49AM -0800, Anton Vorontsov wrote:
>> Hi all,
>> 
>> This is the third RFC. As suggested by Minchan Kim, the API is much
>> simplified now (comparing to vmevent_fd):
>> 
>> - As well as Minchan, KOSAKI Motohiro didn't like the timers, so the
>>   timers are gone now;
>> - Pekka Enberg didn't like the complex attributes matching code, and so it
>>   is no longer there;
>> - Nobody liked the raw vmstat attributes, and so they were eliminated too.
>> 
>> But, conceptually, it is the exactly the same approach as in v2: three
>> discrete levels of the pressure -- low, medium and oom. The levels are
>> based on the reclaimer inefficiency index as proposed by Mel Gorman, but
>> userland does not see the raw index values. The description why I moved
>> away from reporting the raw 'reclaimer inefficiency index' can be found in
>> v2: http://lkml.org/lkml/2012/10/22/177
>> 
>> While the new API is very simple, it is still extensible (i.e. versioned).
>
> Sorry, I didn't follow previous discussion on this, but could you
> explain what's wrong with memory notifications from memcg?
> As I can see you can get pretty similar functionality using memory
> thresholds on the root cgroup. What's the point?

Related question: are there plans to extend this system call to provide
per-cgroup vm pressure notification?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
