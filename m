Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 51D976B0044
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 00:05:07 -0500 (EST)
Received: by mail-da0-f54.google.com with SMTP id n2so2991736dad.27
        for <linux-mm@kvack.org>; Sun, 23 Dec 2012 21:05:06 -0800 (PST)
Date: Sun, 23 Dec 2012 21:08:17 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6] KSM: numa awareness sysfs knob
Message-ID: <20121224050817.GA25749@kroah.com>
References: <1356319374-13226-1-git-send-email-pholasek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356319374-13226-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Mon, Dec 24, 2012 at 04:22:54AM +0100, Petr Holasek wrote:
> Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_across_nodes
> which control merging pages across different numa nodes.

All sysfs files must be documented in Documentation/ABI, please update
the files there as well (subsystem documentation, like you did, is also
nice, but the ABI files are the required ones.)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
