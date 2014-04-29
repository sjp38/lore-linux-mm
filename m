Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id D7EA26B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 20:00:49 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so5251442eei.5
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 17:00:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s46si24816547eeg.105.2014.04.28.17.00.47
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 17:00:48 -0700 (PDT)
Date: Mon, 28 Apr 2014 20:00:31 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
Message-ID: <20140429000031.GA4284@redhat.com>
References: <535EA976.1080402@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535EA976.1080402@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, davidlohr@hp.com, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Apr 29, 2014 at 12:48:14AM +0530, Srivatsa S. Bhat wrote:
 > Hi,
 > 
 > I hit this during boot on v3.15-rc3, just once so far.
 > Subsequent reboots went fine, and a few quick runs of multi-
 > threaded ebizzy also didn't recreate the problem.
 > 
 > The kernel I was running was v3.15-rc3 + some totally
 > unrelated cpufreq patches.

Could you post those patches somewhere ?
They may not be directly related to the code in the trace, but if
they are randomly corrupting memory, maybe that would explain things ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
