Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9124E6B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 13:44:37 -0500 (EST)
Date: Mon, 10 Jan 2011 10:44:16 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/4] De-couple sysfs memory directories from memory
 sections
Message-ID: <20110110184416.GA18974@kroah.com>
References: <4D2B4B38.80102@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D2B4B38.80102@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2011 at 12:08:56PM -0600, Nathan Fontenot wrote:
> This is a re-send of the remaining patches that did not make it
> into the last kernel release for de-coupling sysfs memory
> directories from memory sections.  The first three patches of the
> previous set went in, and this is the remaining patches that
> need to be applied.

Well, it's a bit late right now, as we are merging stuff that is already
in our trees, and we are busy with that, so this is likely to be ignored
until after .38-rc1 is out.

So, care to resend this after .38-rc1 is out so people can pay attention
to it?


> The root of this issue is in sysfs directory creation. Every time
> a directory is created a string compare is done against all sibling
> directories to ensure we do not create duplicates.  The list of
> directory nodes in sysfs is kept as an unsorted list which results
> in this being an exponentially longer operation as the number of
> directories are created.

Are you sure this is still an issue?  I thought we solved this last
kernel or so with a simple patch?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
