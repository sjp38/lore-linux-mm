Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0866B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:14:12 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so8135082obc.7
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:14:11 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g125si5011690oia.112.2015.01.26.07.14.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 07:14:11 -0800 (PST)
Date: Mon, 26 Jan 2015 18:13:59 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH -mm] slab: update_memcg_params: explicitly check that old
 array != NULL
Message-ID: <20150126151359.GD6507@mwanda>
References: <20150126085638.GA6507@mwanda>
 <1422266479-29098-1-git-send-email-vdavydov@parallels.com>
 <20150126101902.GC6507@mwanda>
 <20150126104534.GA28978@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150126104534.GA28978@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 01:45:34PM +0300, Vladimir Davydov wrote:
> On Mon, Jan 26, 2015 at 01:23:05PM +0300, Dan Carpenter wrote:
> > On Mon, Jan 26, 2015 at 01:01:19PM +0300, Vladimir Davydov wrote:
> > > This warning is false-positive, because @old equals NULL iff
> > > @memcg_nr_cache_ids equals 0.
> > 
> > I don't see how it could be a false positive.  The "old" pointer is
> > dereferenced inside the call to memset() so unless memset is a macro the
> > compiler isn't going to optimize the dereference away.
> 
> old->entries is not dereferenced: memcg_cache_array->entries is not a
> pointer - it is embedded to the memcg_cache_array struct.

Ah.  Ok.  Thanks.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
