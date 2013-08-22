Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B73DB6B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 18:40:04 -0400 (EDT)
Date: Thu, 22 Aug 2013 15:40:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] memcg: add per cgroup writeback pages accounting
Message-Id: <20130822154002.ce4310d865ede3a0d30f0ce8@linux-foundation.org>
In-Reply-To: <1377165190-24143-1-git-send-email-handai.szj@taobao.com>
References: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
	<1377165190-24143-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Thu, 22 Aug 2013 17:53:10 +0800 Sha Zhengju <handai.szj@gmail.com> wrote:

> This patch is to add memcg routines to count writeback pages

Well OK, but why?  What use is the feature?  In what ways are people
suffering due to its absence?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
