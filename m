Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 0F92A6B0037
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 20:07:40 -0400 (EDT)
Date: Mon, 18 Mar 2013 20:07:32 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1363651652-dcf5qvg4-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130318155125.GT10192@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130318155125.GT10192@dhcp22.suse.cz>
Subject: Re: [PATCH 9/9] remove /proc/sys/vm/hugepages_treat_as_movable
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Mon, Mar 18, 2013 at 04:51:25PM +0100, Michal Hocko wrote:
> On Thu 21-02-13 14:41:48, Naoya Horiguchi wrote:
> > Now hugepages are definitely movable. So allocating hugepages from
> > ZONE_MOVABLE is natural and we have no reason to keep this parameter.
> 
> The sysctl is a part of user interface so you shouldn't remove it right
> away. What we can do is to make it noop and only WARN() that the
> interface will be removed later so that userspace can prepare for that.
> 

Yes, you're right. I'll replace the handler with noop.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
