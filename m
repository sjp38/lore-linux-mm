Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8906B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:20:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c13-v6so13779576ede.6
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 03:20:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k16-v6si6126762ejq.34.2018.10.16.03.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 03:20:15 -0700 (PDT)
Date: Tue, 16 Oct 2018 12:20:09 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v7 1/6] mm: split SWP_FILE into SWP_ACTIVATED and SWP_FS
Message-ID: <20181016102009.GA29418@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1536704650.git.osandov@fb.com>
 <6d63d8668c4287a4f6d203d65696e96f80abdfc7.1536704650.git.osandov@fb.com>
 <20181012135934.b8dbbaaf8a01011ec21b5aba@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181012135934.b8dbbaaf8a01011ec21b5aba@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Omar Sandoval <osandov@osandov.com>, linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Fri, Oct 12, 2018 at 01:59:34PM -0700, Andrew Morton wrote:
> On Tue, 11 Sep 2018 15:34:44 -0700 Omar Sandoval <osandov@osandov.com> wrote:
> 
> > From: Omar Sandoval <osandov@fb.com>
> > 
> > The SWP_FILE flag serves two purposes: to make swap_{read,write}page()
> > go through the filesystem, and to make swapoff() call
> > ->swap_deactivate(). For Btrfs, we want the latter but not the former,
> > so split this flag into two. This makes us always call
> > ->swap_deactivate() if ->swap_activate() succeeded, not just if it
> > didn't add any swap extents itself.
> > 
> > This also resolves the issue of the very misleading name of SWP_FILE,
> > which is only used for swap files over NFS.
> > 
> 
> Acked-by: Andrew Morton <akpm@linux-foundation.org>

Andrew, can you please take the two patches through the mm tree? I'm not
going to send the btrfs swap patches in the upcoming merge window so it
would not make sense to add plain MM changes to btrfs tree.  The whole
series has been in linux-next for some time so it's just moving between
trees. Thanks.
