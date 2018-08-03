Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFBFC6B0273
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 16:18:19 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id y1-v6so781961lfe.5
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 13:18:19 -0700 (PDT)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id p21-v6si1854417lfj.213.2018.08.03.13.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 13:18:18 -0700 (PDT)
Date: Fri, 3 Aug 2018 22:18:16 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 2/2] sparc32: tidy up ramdisk memory reservation
Message-ID: <20180803201816.GB7789@ravnborg.org>
References: <1533210833-14748-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1533210833-14748-3-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533210833-14748-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mike.

On Thu, Aug 02, 2018 at 02:53:53PM +0300, Mike Rapoport wrote:
> The detection and reservation of ramdisk memory were separated to allow
> bootmem bitmap initialization after the ramdisk boundaries are detected.
> Since the bootmem initialization is removed, the reservation of ramdisk
> memory can be done immediately after its boundaries are found.

When touching this area could you look
at introducing a find_ramdisk() function like
we do for sparc64?
It is always nice when the codebases look alike.
Then you could combine your simplification
with some refactoring that further increases
readability.

See:
https://patchwork.ozlabs.org/patch/151194/
for my attempt from long time ago.

	Sam
