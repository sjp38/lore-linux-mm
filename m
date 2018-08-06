Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80A946B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 09:08:43 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id p8-v6so2389820ljg.10
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 06:08:43 -0700 (PDT)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id b190-v6si5146731lfg.154.2018.08.06.06.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 06:08:41 -0700 (PDT)
Date: Mon, 6 Aug 2018 15:08:39 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v2 2/3] sparc32: switch to NO_BOOTMEM
Message-ID: <20180806130839.GA23652@ravnborg.org>
References: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1533552755-16679-3-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533552755-16679-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 06, 2018 at 01:52:34PM +0300, Mike Rapoport wrote:
> Each populated sparc_phys_bank is added to memblock.memory. The
> reserve_bootmem() calls are replaced with memblock_reserve(), and the
> bootmem bitmap initialization is droppped.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
