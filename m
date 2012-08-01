Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 0BD656B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 11:06:41 -0400 (EDT)
Message-ID: <501945F9.2030402@redhat.com>
Date: Wed, 01 Aug 2012 11:06:33 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <50118E7F.8000609@redhat.com> <50120FA8.20409@redhat.com> <20120727102356.GD612@suse.de> <5016DC5F.7030604@redhat.com> <20120731124650.GO612@suse.de> <50181AA1.0@redhat.com> <20120731200650.GB19524@tiehlicka.suse.cz> <50189857.4000501@redhat.com> <20120801082036.GC4436@tiehlicka.suse.cz> <20120801123209.GK4436@tiehlicka.suse.cz>
In-Reply-To: <20120801123209.GK4436@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 08/01/2012 08:32 AM, Michal Hocko wrote:
>
> I am really lame :/. The previous patch is wrong as well for goto out
> branch. The updated patch as follows:
This patch worked fine Michal!  You and Mel can duke it out over who's 
is best. :)

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
