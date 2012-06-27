Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D48F56B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:52:40 -0400 (EDT)
Message-ID: <4FEB0177.1070303@parallels.com>
Date: Wed, 27 Jun 2012 16:49:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
References: <1340725634-9017-1-git-send-email-glommer@parallels.com> <1340725634-9017-3-git-send-email-glommer@parallels.com> <20120626180451.GP3869@google.com> <20120626220809.GA4653@tiehlicka.suse.cz> <20120626221452.GA15811@google.com> <20120627125119.GE5683@tiehlicka.suse.cz>
In-Reply-To: <20120627125119.GE5683@tiehlicka.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On 06/27/2012 04:51 PM, Michal Hocko wrote:
>> > Just disallow clearing .use_hierarchy if it was mounted with the
>> > option? 
> Dunno, mount option just doesn't feel right. We do not offer other
> attributes to be set by them so it would be just confusing. Besides that
> it would require an integration into existing tools like cgconfig which
> is yet another pain just because of something that we never promissed to
> keep a certain way. There are many people who don't work with mount&fs
> cgroups directly but rather use libcgroup for that...

myself included.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
