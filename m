From: Neil Brown <neilb@suse.de>
Date: Tue, 1 May 2007 10:09:40 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17974.34116.479061.912980@notabene.brown>
Subject: nfsd/md patches Re: 2.6.22 -mm merge plans
In-Reply-To: message from Andrew Morton on Monday April 30
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday April 30, akpm@linux-foundation.org wrote:
> 
>  remove-nfs4_acl_add_ace.patch
>  the-nfsv2-nfsv3-server-does-not-handle-zero-length-write.patch
>  knfsd-rename-sk_defer_lock-to-sk_lock.patch
>  nfsd-nfs4state-remove-unnecessary-daemonize-call.patch
>  rpc-add-wrapper-for-svc_reserve-to-account-for-checksum.patch
> 
> nfsd things - will merge after checking with Neil.
> 

All acked, though that last one won't fix any oopses like the comment
hopes for - I really should look into that.


> 
>  drivers-mdc-use-array_size-macro-when-appropriate.patch
>  md-cleanup-use-seq_release_private-where-appropriate.patch
>  md-remove-broken-sigkill-support.patch
> 
> Will merge after checking with Neil

NAK on md-remove-broken-sigkill-support.patch - I'll follow up the
original mail.

ACK on the other two.


> 
>  md-dm-reduce-stack-usage-with-stacked-block-devices.patch
> 
> Will we ever fix this?
> 

I think we have several votes for "just merge it".  I don't think
there are known problems with it.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
