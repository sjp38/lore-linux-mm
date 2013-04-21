Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E8AC26B0034
	for <linux-mm@kvack.org>; Sun, 21 Apr 2013 15:55:38 -0400 (EDT)
Date: Sun, 21 Apr 2013 15:55:34 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 3/3] ext4: mark metadata blocks using bh flags
Message-ID: <20130421195534.GA13543@thunk.org>
References: <20130421000522.GA5054@thunk.org>
 <1366502828-7793-1-git-send-email-tytso@mit.edu>
 <1366502828-7793-3-git-send-email-tytso@mit.edu>
 <5173828A.2030809@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5173828A.2030809@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org, Linux Kernel Developers List <linux-kernel@vger.kernel.org>, mgorman@suse.de

On Sun, Apr 21, 2013 at 08:09:14AM +0200, Jiri Slaby wrote:
> On 04/21/2013 02:07 AM, Theodore Ts'o wrote:
> > This allows metadata writebacks which are issued via block device
> > writeback to be sent with the current write request flags.
> 
> Hi, where do these come from?
> fs/ext4/ext4_jbd2.c: In function a??__ext4_handle_dirty_metadataa??:
> fs/ext4/ext4_jbd2.c:218:2: error: implicit declaration of function
> a??mark_buffer_metaa?? [-Werror=implicit-function-declaration]
> fs/ext4/ext4_jbd2.c:219:2: error: implicit declaration of function
> a??mark_buffer_prioa?? [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors

They are defined by "[PATCH 2/3] buffer: add BH_Prio and BH_Meta flags" here:

+BUFFER_FNS(Meta, meta)
+BUFFER_FNS(Prio, prio)

When you tried applying this patch, did you try applying all three
patches in the patch series?

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
