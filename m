Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E31306B000A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 09:09:05 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id z24-v6so2386371lji.16
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 06:09:05 -0700 (PDT)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id 90-v6si6312156lje.376.2018.08.06.06.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 06:09:04 -0700 (PDT)
Date: Mon, 6 Aug 2018 15:09:02 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v2 3/3] sparc32: split ramdisk detection and reservation
 to a helper function
Message-ID: <20180806130902.GB23652@ravnborg.org>
References: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1533552755-16679-4-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533552755-16679-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 06, 2018 at 01:52:35PM +0300, Mike Rapoport wrote:
> The detection and reservation of ramdisk memory were separated to allow
> bootmem bitmap initialization after the ramdisk boundaries are detected.
> Since the bootmem initialization is removed, the reservation of ramdisk
> memory is done immediately after its boundaries are found.
> 
> Split the entire block into a separate helper function.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Suggested-by: Sam Ravnborg <sam@ravnborg.org>
Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
