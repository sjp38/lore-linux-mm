Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 87EC78D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 23:30:26 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p194BdOk027786
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 23:11:50 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0689072804D
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 23:30:24 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p194UN6J192296
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 23:30:23 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p194UM9f018502
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 21:30:22 -0700
Message-ID: <4D52185C.7080405@linux.vnet.ibm.com>
Date: Tue, 08 Feb 2011 20:30:20 -0800
From: "Venkateswararao Jujjuri (JV)" <jvrao@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] Avoid cache duplication in virtual/paravirtual filesystems
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: linux-mm@kvack.org

I would like to propose a discussion on VirtFS, a 9P based paravirtual
filesystem for KVM.

Discuss unique advantages and issues with the paravirtual filesystems

I would like to discuss and get community feedback and ideas on how can we avoid
cache
duplication(data and metadata) between host and guests.?

Given that both server (host) and client (guest) is running on the same hardware
we should
be able to avoid double caching of both(host and guest) filesystems.

For details about VirtFS, please see my OLS paper
http://www.sciweavers.org/publications/virtfs-virtualization-aware-file-system-pass-through

Thanks
Venkateswararao Jujjuri (JV)
VirtFS - KVM
LTC, IBM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
