Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C40E36B0002
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 03:11:20 -0500 (EST)
Message-ID: <510632BD.3010702@parallels.com>
Date: Mon, 28 Jan 2013 12:11:41 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: [ATTEND][LSF/MM TOPIC] the memory controller
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

Hi,

I've been working actively over the past year with the memory
controller, in particular its usage to track special bits of interest in
kernel memory land. As this work progress, I'd like to propose and
participate in the following discussions in the upcoming LSF/MM:

* memcg kmem shrinking: as memory pressure appears within memcg, we need
to shrink some of the slab objects attributed to the group, maintaining
isolation as much as possible. The scheme also needs to allow for global
reclaim to keep working reliably, and of course, be memory efficient.

* memcg/global oom handling: I believe that the OOM killer could be
significantly improved to allow for more deterministic killing of tasks,
specially in containers scenarios where memcg is heavily deployed. In
some situations, a group encompasses a whole service, and under
pressure, it would be better to shut down the group altogether with all
its tasks, while in others it would be better to keep the current
behavior of shooting down a single task.

I also believe I will be able to help with general discussions
concerning the memory controller in general, since pursuing ways to
improve it - specially efficiency-wise - seems to be a recurring (and
thankfully fruitful) topic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
