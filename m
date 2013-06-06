Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id BAAB46B003A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 17:15:03 -0400 (EDT)
Date: Thu, 6 Jun 2013 14:15:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 00/25] shrinkers rework: per-numa, generic lists,
 etc
Message-Id: <20130606141501.72d80a9a5c7bce4c4a002906@linux-foundation.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com

On Fri,  7 Jun 2013 00:34:33 +0400 Glauber Costa <glommer@openvz.org> wrote:

> Andrew,
> 
> I believe I have addressed most of your comments, while attempting to address
> all of them. If there is anything I have missed after this long day, let me
> know and I will go over it promptly.

I'll trust you - I've had my fill of costacode this week ;)

Can you send over a nice introductory [patch 0/n] as an overview of the
whole series?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
