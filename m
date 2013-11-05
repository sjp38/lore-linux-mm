Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B352A6B00A6
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 18:53:23 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so9620869pab.38
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 15:53:23 -0800 (PST)
Received: from psmtp.com ([74.125.245.131])
        by mx.google.com with SMTP id n5si15400161pav.156.2013.11.05.15.53.21
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 15:53:22 -0800 (PST)
Date: Tue, 5 Nov 2013 15:53:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] mm: allow to set overcommit ratio more precisely
Message-Id: <20131105155319.732dcbefb162c2ee4716ef9d@linux-foundation.org>
In-Reply-To: <1382101019-23563-2-git-send-email-jmarchan@redhat.com>
References: <1382101019-23563-1-git-send-email-jmarchan@redhat.com>
	<1382101019-23563-2-git-send-email-jmarchan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

On Fri, 18 Oct 2013 14:56:59 +0200 Jerome Marchand <jmarchan@redhat.com> wrote:

> Some applications that run on HPC clusters are designed around the
> availability of RAM and the overcommit ratio is fine tuned to get the
> maximum usage of memory without swapping. With growing memory, the 1%
> of all RAM grain provided by overcommit_ratio has become too coarse
> for these workload (on a 2TB machine it represents no less than
> 20GB).
> 
> This patch adds the new overcommit_ratio_ppm sysctl variable that
> allow to set overcommit ratio with a part per million precision.
> The old overcommit_ratio variable can still be used to set and read
> the ratio with a 1% precision. That way, overcommit_ratio interface
> isn't broken in any way that I can imagine.

The way we've permanently squished this mistake in the past is to
switch to "bytes".  See /proc/sys/vm/*bytes.

Would that approach work in this case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
