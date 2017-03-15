Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5571A6B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 10:09:30 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id u138so55507836ywg.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 07:09:30 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id t6si654333ybf.65.2017.03.15.07.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 07:09:29 -0700 (PDT)
Date: Wed, 15 Mar 2017 10:09:27 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [RFC PATCH] mm: retry writepages() on ENOMEM when doing an data
 integrity writeback
Message-ID: <20170315140927.g5ylzcbxrvjqune3@thunk.org>
References: <20170309090449.GD15874@quack2.suse.cz>
 <20170315050743.5539-1-tytso@mit.edu>
 <20170315115933.GF12989@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315115933.GF12989@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Wed, Mar 15, 2017 at 12:59:33PM +0100, Jan Kara wrote:
> > +	while (1) {
> > +		if (mapping->a_ops->writepages)
> > +			ret = mapping->a_ops->writepages(mapping, wbc);
> > +		else
> > +			ret = generic_writepages(mapping, wbc);
> > +		if ((ret != ENOMEM) || (wbc->sync_mode != WB_SYNC_ALL))
> 
> -ENOMEM I guess...

Oops.  Thanks for noticing!

Unless anyone has any objections I plan to carry this in the ext4
tree.

						- Ted
