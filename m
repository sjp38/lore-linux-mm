Message-ID: <3AB7B5F5.F1274CD@mandrakesoft.com>
Date: Tue, 20 Mar 2001 14:56:37 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: kmalloc with GFP_DMA, or get_free_pages!!!
References: <85256A15.00692E23.00@alpha2.storage.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jalajadevi Ganapathy <jganapat@Storage.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Jalajadevi Ganapathy wrote:
> 
> To allocate memory for DMA operations,

Use PCI DMA.  Yes, even for ISA devices.  Read
Documentation/DMA-mapping.txt.

-- 
Jeff Garzik       | May you have warm words on a cold evening,
Building 1024     | a full mooon on a dark night,
MandrakeSoft      | and a smooth road all the way to your door.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
