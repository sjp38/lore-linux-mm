Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 4 Feb 2013 16:18:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-Id: <20130204161848.bfd36176.akpm@linux-foundation.org>
In-Reply-To: <20130204160624.5c20a8a0.akpm@linux-foundation.org>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
	<1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
	<20130204160624.5c20a8a0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org


Also...

On Mon, 4 Feb 2013 16:06:24 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > +put_page:
> > +	/* Undo the effects of former get_user_pages(), we won't pin anything */
> > +	for (i = 0; i < ret; i++)
> > +		put_page(pages[i]);

We can use release_pages() here.

release_pages() is designed to be more efficient when we're putting the
final reference to (most of) the pages.  It probably has little if any
benefit when putting still-in-use pages, as we're doing here.

But please consider...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
