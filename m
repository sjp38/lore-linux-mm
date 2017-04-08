Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDD716B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 06:38:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s82so4254653pfk.3
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 03:38:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j7si7890476pfe.166.2017.04.08.03.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Apr 2017 03:38:35 -0700 (PDT)
Date: Sat, 8 Apr 2017 12:38:21 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv3 00/22] Ion clean up in preparation in moving out of
 staging
Message-ID: <20170408103821.GA12084@kroah.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Daniel Vetter <daniel.vetter@intel.com>, Brian Starkey <brian.starkey@arm.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Mon, Apr 03, 2017 at 11:57:42AM -0700, Laura Abbott wrote:
> Hi,
> 
> This is v3 of the series to do some serious Ion cleanup in preparation for
> moving out of staging. I didn't hear much on v2 so I'm going to assume
> people are okay with the series as is. I know there were still some open
> questions about moving away from /dev/ion but in the interest of small
> steps I'd like to go ahead and merge this series assuming there are no more
> major objections. More work can happen on top of this.

I've applied patches 3-11 as those were independant of the CMA changes.
I'd like to take the rest, including the CMA changes, but I need an ack
from someone dealing with the -mm tree before I can do that.

Or, if they just keep ignoring it, I guess I can take them :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
