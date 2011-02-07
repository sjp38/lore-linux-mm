Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A57FD8D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 07:40:53 -0500 (EST)
Message-ID: <4D4FE849.5070004@parallels.com>
Date: Mon, 07 Feb 2011 15:40:41 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] Memory controller discussions
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linuxfoundation.org
Cc: James Bottomley <James.Bottomley@suse.de>, Linux MM <linux-mm@kvack.org>

Hi.

On the MM sessions I'd like to participate in the memcg discussions.

Topics that are of the most interest to me are:

* kernel memory accounting
* dirty set management
* VM overcommit management
* LRU lists management

The first two issues are already described in respectively [1] and [2].
The 3rd issue was raised many times on the mailing lists, but I haven't
seen whether it was resolved finally and  would like to bring it up again.

Now about the 4th one (LRU lists management).

The existing memcg model uses page_cgroup object to track the page to 
memcg relation. Each page that belongs to some memcg has that object
allocated.

Such a design doesn't look very elegant from my POV, provides a memory
overhead and makes the mm/vmscan.c code looks not very nice, since each
page lives in up to two LRU lists :\

I wanted to propose the scheme used in the OpenVZ RHEL6-based kernel [3].
Briefly - in that scheme we introduce a lru_lists object which contains
the LRU list heads and statistics for that lists and each page belong so
some lru_list. A new memcg should allocate and use its own new lru_list.


[1] http://marc.info/?l=linux-mm&m=129686460401990
[2] http://marc.info/?l=linux-mm&m=129684641013000
[3] http://community.livejournal.com/openvz/34522.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
