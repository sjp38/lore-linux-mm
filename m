Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7194D8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 17:56:34 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p2TLuW63017814
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:56:32 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz33.hot.corp.google.com with ESMTP id p2TLuVkE016824
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:56:31 -0700
Received: by qyk7 with SMTP id 7so2552910qyk.12
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:56:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329145237.b5bb7fbf.akpm@linux-foundation.org>
References: <1301378186-23199-1-git-send-email-yinghan@google.com>
	<1301378186-23199-2-git-send-email-yinghan@google.com>
	<20110329145237.b5bb7fbf.akpm@linux-foundation.org>
Date: Tue, 29 Mar 2011 14:56:30 -0700
Message-ID: <BANLkTi=NSsHk9aZJYj2rPGoOvKvVif3aEg@mail.gmail.com>
Subject: Re: [PATCH V3 1/2] count the soft_limit reclaim in global background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Mar 29, 2011 at 2:52 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 28 Mar 2011 22:56:25 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> @@ -1442,6 +1443,7 @@ static int mem_cgroup_hierarchical_reclaim(struct =
mem_cgroup *root_mem,
>> =A0 =A0 =A0 bool shrink =3D reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
>> =A0 =A0 =A0 bool check_soft =3D reclaim_options & MEM_CGROUP_RECLAIM_SOF=
T;
>
> This function rather abuses the concept of `bool'.

hmm. then maybe a separate patch to fix that :)

thanks

--Ying
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
