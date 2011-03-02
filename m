Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 13D2C8D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 05:04:23 -0500 (EST)
Date: Wed, 2 Mar 2011 11:04:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] page_cgroup array is never stored on reserved pages
Message-ID: <20110302100418.GC19651@tiehlicka.suse.cz>
References: <20110228101129.GE4648@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110228101129.GE4648@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>

Hi Andrew,
here is the updated follow up patch refreshed on top of the current
mmotm (2011-02-10-16-26) with a checkpatch cleanup:
--- 
