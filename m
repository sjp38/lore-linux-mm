Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 389F26B005D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 21:07:39 -0500 (EST)
Date: Thu, 29 Nov 2012 18:07:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [memcg:since-3.6 341/499]
 drivers/virtio/virtio_balloon.c:157:2-8: preceding lock on line 136
Message-Id: <20121129180737.d4b308b6.akpm@linux-foundation.org>
In-Reply-To: <20121130020015.GA29687@localhost>
References: <50b79f52.Rxsdi7iwHf+1mkK5%fengguang.wu@intel.com>
	<20121130002848.GA28177@localhost>
	<20121129164616.6c308ce0.akpm@linux-foundation.org>
	<20121130020015.GA29687@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Rafael Aquini <aquini@redhat.com>, kbuild@01.org, Julia Lawall <julia.lawall@lip6.fr>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, 30 Nov 2012 10:00:15 +0800
Fengguang Wu <fengguang.wu@intel.com> wrote:

> Thanks for sharing the code and howto! It won't be hard for me to
> follow that rule, however it seems a bit more straightforward to
> detect the "fix" magic keyword in the subject line?

OK, including "fix" is easy ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
