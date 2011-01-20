Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D29BF8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:51:48 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KGbJqE021423
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:37:20 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3D1564DE803B
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:48:27 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KGpkpx472110
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:51:46 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KGpja2028708
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:51:46 -0700
Message-ID: <4D386820.5080902@austin.ibm.com>
Date: Thu, 20 Jan 2011 10:51:44 -0600
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] De-couple sysfs memory directories from memory sections
References: <4D386498.9080201@austin.ibm.com> <20110120164555.GA30922@kroah.com>
In-Reply-To: <20110120164555.GA30922@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

On 01/20/2011 10:45 AM, Greg KH wrote:
> On Thu, Jan 20, 2011 at 10:36:40AM -0600, Nathan Fontenot wrote:
>> The root of this issue is in sysfs directory creation. Every time
>> a directory is created a string compare is done against sibling
>> directories ( see sysfs_find_dirent() ) to ensure we do not create 
>> duplicates.  The list of directory nodes in sysfs is kept as an
>> unsorted list which results in this being an exponentially longer
>> operation as the number of directories are created.
> 
> Again, are you sure about this?  I thought we resolved this issue in the
> past, but you were going to check it.  Did you?
> 

Yes, the string compare is still present in the sysfs code.  There was
discussion around this sometime last year when I sent a patch out that
stored the directory entries in something other than a linked list.
That patch was rejected but it was agreed that something should be done.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
