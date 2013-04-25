Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 689DF6B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 14:34:08 -0400 (EDT)
Received: by mail-ve0-f201.google.com with SMTP id m1so159744ves.2
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 11:34:07 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
References: <1366705329-9426-1-git-send-email-glommer@openvz.org>
	<1366705329-9426-2-git-send-email-glommer@openvz.org>
	<xr937gjrhg1f.fsf@gthelen.mtv.corp.google.com>
	<51790A73.3030805@parallels.com>
Date: Thu, 25 Apr 2013 11:34:05 -0700
In-Reply-To: <51790A73.3030805@parallels.com> (Glauber Costa's message of
	"Thu, 25 Apr 2013 14:50:27 +0400")
Message-ID: <xr93txmuwjc2.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Apr 25 2013, Glauber Costa wrote:

> On 04/24/2013 11:42 PM, Greg Thelen wrote:
>>> +	vmpr->notify_userspace = true;
>> Should notify_userspace get cleared sometime?  Seems like we might need
>> to clear or decrement notify_userspace in vmpressure_event() when
>> calling eventfd_signal().
>> 
> I am folding the attached patch and keeping the acks unless the ackers
> oppose.
>
> Greg, any other problem you spot here? Thanks for the review BTW.

Looks good to me.  Feel free to add my tag to the patch with
vmpressure.diff folded in.

Reviewed-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
