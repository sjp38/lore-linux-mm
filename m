Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 597986B0032
	for <linux-mm@kvack.org>; Sat, 18 May 2013 03:19:51 -0400 (EDT)
Message-ID: <51972BC1.7020704@parallels.com>
Date: Sat, 18 May 2013 11:20:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 12/31] fs: convert inode and dentry shrinking to be
 node aware
References: <1368382432-25462-1-git-send-email-glommer@openvz.org> <1368382432-25462-13-git-send-email-glommer@openvz.org> <20130514095200.GI29466@dastard> <5193A95E.70205@parallels.com> <20130516000216.GC24635@dastard> <5195302A.2090406@parallels.com> <20130517005134.GK24635@dastard> <5195DC59.8000205@parallels.com> <51964381.8010406@parallels.com> <20130518033941.GB6495@dastard>
In-Reply-To: <20130518033941.GB6495@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On 05/18/2013 07:39 AM, Dave Chinner wrote:
> Sorry for not doing more here 
I forgive you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
