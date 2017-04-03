Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A170B6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 12:30:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d66so48542332qkb.0
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 09:30:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si12336118qth.121.2017.04.03.09.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 09:30:36 -0700 (PDT)
Date: Mon, 3 Apr 2017 18:30:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH for 4.11] userfaultfd: report actual registered features
 in fdinfo
Message-ID: <20170403163034.GD5107@redhat.com>
References: <1491140181-22121-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170403143523.GC5107@redhat.com>
 <20170403151024.GA14802@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403151024.GA14802@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

Hello Mike,

On Mon, Apr 03, 2017 at 06:10:24PM +0300, Mike Rapoport wrote:
> Actually, I've found these details in /proc useful when I was experimenting
> with checkpoint-restore of an application that uses userfaultfd. With
> interface in /proc/<pid>/ we know exactly which process use userfaultfd and
> can act appropriately.

You've to be somewhat serialized by other means though, because
"exactly" has a limit with fdinfo. For example by the time read()
returns, the uffd may have been closed already by the app (just the
uffd isn't ->release()d yet as the last fput has yet to run, the
fdinfo runs the last fput in such case). As long as you can cope with
this and you've a stable fdinfo it's ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
