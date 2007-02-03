From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: [patch 0/9] buffered write deadlock fix
Date: Sat, 3 Feb 2007 23:31:45 +0800
Message-ID: <20070203153145.GA3980__45888.3388237611$1170517118$gmane$org@mail.ustc.edu.cn>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070202155232.babe1a52.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Message-ID: <20070203153145.GA3980@mail.ustc.edu.cn>
Content-Disposition: inline
In-Reply-To: <20070202155232.babe1a52.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Suparna Bhattacharya <suparna@in.ibm.com>
List-Id: linux-mm.kvack.org

On Fri, Feb 02, 2007 at 03:52:32PM -0800, Andrew Morton wrote:
> Bugfixes come first, so I will drop readahead and fsaio and git-block to get
> this work completed if needed - please work agaisnt mainline.

OK with readahead.

There are too much fixes in the series.  I'd like to fold them up and
update some change logs. And then there would be one more update.

Regards,
Wu
