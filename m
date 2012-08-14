Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 703886B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 08:30:00 -0400 (EDT)
Message-ID: <502A4410.6070201@parallels.com>
Date: Tue, 14 Aug 2012 16:26:56 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: mmotm 2012-08-13-16-55 uploaded
References: <20120813235651.00A13100047@wpzn3.hot.corp.google.com> <20120814105349.GA6905@dhcp22.suse.cz>
In-Reply-To: <20120814105349.GA6905@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On 08/14/2012 02:53 PM, Michal Hocko wrote:
> On Mon 13-08-12 16:56:50, Andrew Morton wrote:
>> > The mm-of-the-moment snapshot 2012-08-13-16-55 has been uploaded to
>> > 
>> >    http://www.ozlabs.org/~akpm/mmotm/
> -mm git tree has been updated as well. You can find the tree at
> https://github.com/mstsxfx/memcg-devel.git since-3.5
> 
> tagged as mmotm-2012-08-13-16-55
> 

On top of this tree, people following the kmemcg development may also
want to checkout

   git://github.com/glommer/linux.git memcg-3.5/kmemcg-stack

A branch called memcg-3.5/kmemcg-slab is also available with the slab
changes ontop.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
