Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 91D016008F1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 05:40:03 -0400 (EDT)
Subject: Re: [PATCH V3] Split executable and non-executable mmap tracking
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1274193049-25997-1-git-send-email-ebmunson@us.ibm.com>
References: <1274193049-25997-1-git-send-email-ebmunson@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 25 May 2010 11:39:55 +0200
Message-ID: <1274780395.5882.710.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: mingo@elte.hu, acme@redhat.com, arjan@linux.intel.com, anton@samba.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-05-18 at 15:30 +0100, Eric B Munson wrote:

> +				mmap_data      :  1. /* non-exec mmap data    */

Things compile better if you use a ',' there :-)

anyway, fixed it up and will continue the compile..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
