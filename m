Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0756B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:00:03 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id h61-v6so2957748pld.3
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 03:00:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3-v6si3798317pls.530.2018.03.15.03.00.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 03:00:01 -0700 (PDT)
Subject: Re: [PATCH 00/16] remove eight obsolete architectures
References: <20180314143529.1456168-1-arnd@arndb.de>
 <2929.1521106970@warthog.procyon.org.uk>
From: Hannes Reinecke <hare@suse.de>
Message-ID: <6c9d075c-d7a8-72a5-9b2d-af1feaa06c6c@suse.de>
Date: Thu, 15 Mar 2018 10:59:58 +0100
MIME-Version: 1.0
In-Reply-To: <2929.1521106970@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi@vger.kernel.org, linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 03/15/2018 10:42 AM, David Howells wrote:
> Do we have anything left that still implements NOMMU?
> 
RISC-V ?
(evil grin :-)

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 NA 1/4 rnberg
GF: F. ImendA?rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG NA 1/4 rnberg)
