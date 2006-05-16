From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: cleanup swap unused warning
Date: Tue, 16 May 2006 20:55:36 +1000
References: <200605102132.41217.kernel@kolivas.org> <Pine.LNX.4.64.0605101604330.7472@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0605101604330.7472@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200605162055.36957.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thursday 11 May 2006 09:04, Christoph Lameter wrote:
> On Wed, 10 May 2006, Con Kolivas wrote:
> > Are there any users of swp_entry_t when CONFIG_SWAP is not defined?
>
> Yes, a migration entry is a form of swap entry.

mm/vmscan.c: In function a??remove_mappinga??:
mm/vmscan.c:387: warning: unused variable a??swapa??

Ok so if we fix it by making swp_entry_t __attribute__((__unused__) we break 
swap migration code?

If we make swap_free() an empty static inline function then gcc compiles in 
the variable needlessly and we won't know it.

For the moment let's continue putting up with the warning.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
