Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 598B86B033D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 09:05:43 -0400 (EDT)
Message-ID: <4FE86188.6060700@parallels.com>
Date: Mon, 25 Jun 2012 17:03:04 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 06/25] memcg: Make it possible to use the stock for
 more than one page.
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-7-git-send-email-glommer@parallels.com> <20120620132804.GF5541@tiehlicka.suse.cz>
In-Reply-To: <20120620132804.GF5541@tiehlicka.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>

On 06/20/2012 05:28 PM, Michal Hocko wrote:
> I guess you want:
> 	if (nr_pages > CHARGE_BATCH)
> 		return false;
>
> because you don't want to try to use stock for THP pages.

Done, thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
