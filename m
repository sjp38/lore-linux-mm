Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2D58D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:47:40 -0500 (EST)
Date: Thu, 20 Jan 2011 08:45:55 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/4] De-couple sysfs memory directories from memory
 sections
Message-ID: <20110120164555.GA30922@kroah.com>
References: <4D386498.9080201@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D386498.9080201@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 20, 2011 at 10:36:40AM -0600, Nathan Fontenot wrote:
> The root of this issue is in sysfs directory creation. Every time
> a directory is created a string compare is done against sibling
> directories ( see sysfs_find_dirent() ) to ensure we do not create 
> duplicates.  The list of directory nodes in sysfs is kept as an
> unsorted list which results in this being an exponentially longer
> operation as the number of directories are created.

Again, are you sure about this?  I thought we resolved this issue in the
past, but you were going to check it.  Did you?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
