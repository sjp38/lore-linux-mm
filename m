Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id F0B2D6B006C
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 17:28:45 -0500 (EST)
Message-ID: <50F7290D.9090308@web.de>
Date: Wed, 16 Jan 2013 23:26:21 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] ata: sata_mv: fix sg_tbl_pool alignment
References: <20130115175020.GA3764@kroah.com> <20130115201617.GC25500@titan.lakedaemon.net> <20130115215602.GF25500@titan.lakedaemon.net> <50F5F1B7.3040201@web.de> <20130116024014.GH25500@titan.lakedaemon.net> <50F61D86.4020801@web.de> <50F66B1B.40301@web.de> <20130116155045.GI25500@titan.lakedaemon.net> <50F6DDF7.9080605@web.de> <20130116175203.GK25500@titan.lakedaemon.net> <20130116183518.GL25500@titan.lakedaemon.net>
In-Reply-To: <20130116183518.GL25500@titan.lakedaemon.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linaro-mm-sig@lists.linaro.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On 16.01.2013 19:35, Jason Cooper wrote:
>>>> On Wed, Jan 16, 2013 at 09:55:55AM +0100, Soeren Moch wrote:
>>>>> I don't want to say that Mareks patch is wrong, probably it triggers a
>>>>> bug somewhere else! (in em28xx?)
>
> Could you send the output of:
>
> lsusb -v -d VEND:PROD
>
> for the em28xx?
>
> thx,
>
> Jason.
>

Here is the lsusb output for both of my em28xx sticks.

Regards,
Soeren


Bus 001 Device 005: ID 0ccd:00b2 TerraTec Electronic GmbH
Device Descriptor:
   bLength                18
   bDescriptorType         1
   bcdUSB               2.00
   bDeviceClass            0 (Defined at Interface level)
   bDeviceSubClass         0
   bDeviceProtocol         0
   bMaxPacketSize0        64
   idVendor           0x0ccd TerraTec Electronic GmbH
   idProduct          0x00b2
   bcdDevice            1.00
   iManufacturer           3 TERRATEC
   iProduct                1 Cinergy HTC Stick
   iSerial                 2 123456789ABCD
   bNumConfigurations      1
   Configuration Descriptor:
     bLength                 9
     bDescriptorType         2
     wTotalLength          305
     bNumInterfaces          1
     bConfigurationValue     1
     iConfiguration          0
     bmAttributes         0x80
       (Bus Powered)
     MaxPower              500mA
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       0
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       1
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       2
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0ad0  2x 720 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       3
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0c00  2x 1024 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       4
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x1300  3x 768 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       5
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x1380  3x 896 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       6
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x13c0  3x 960 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       7
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x1400  3x 1024 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
Device Qualifier (for other device speed):
   bLength                10
   bDescriptorType         6
   bcdUSB               2.00
   bDeviceClass            0 (Defined at Interface level)
   bDeviceSubClass         0
   bDeviceProtocol         0
   bMaxPacketSize0        64
   bNumConfigurations      1
Device Status:     0x0000
   (Bus Powered)





Bus 001 Device 009: ID 2304:0242 Pinnacle Systems, Inc.
Device Descriptor:
   bLength                18
   bDescriptorType         1
   bcdUSB               2.00
   bDeviceClass            0 (Defined at Interface level)
   bDeviceSubClass         0
   bDeviceProtocol         0
   bMaxPacketSize0        64
   idVendor           0x2304 Pinnacle Systems, Inc.
   idProduct          0x0242
   bcdDevice            1.00
   iManufacturer           1 Pinnacle Systems
   iProduct                2 PCTV 510e
   iSerial                 3 123456789012
   bNumConfigurations      1
   Configuration Descriptor:
     bLength                 9
     bDescriptorType         2
     wTotalLength          305
     bNumInterfaces          1
     bConfigurationValue     1
     iConfiguration          0
     bmAttributes         0x80
       (Bus Powered)
     MaxPower              500mA
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       0
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       1
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0000  1x 0 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       2
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0ad0  2x 720 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       3
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0c00  2x 1024 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       4
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x1300  3x 768 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       5
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x1380  3x 896 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       6
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x13c0  3x 960 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       7
       bNumEndpoints           4
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass      0
       bInterfaceProtocol    255
       iInterface              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0001  1x 1 bytes
         bInterval              11
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x82  EP 2 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x1400  3x 1024 bytes
         bInterval               1
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x00c4  1x 196 bytes
         bInterval               4
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x84  EP 4 IN
         bmAttributes            1
           Transfer Type            Isochronous
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x03ac  1x 940 bytes
         bInterval               1
Device Qualifier (for other device speed):
   bLength                10
   bDescriptorType         6
   bcdUSB               2.00
   bDeviceClass            0 (Defined at Interface level)
   bDeviceSubClass         0
   bDeviceProtocol         0
   bMaxPacketSize0        64
   bNumConfigurations      1
Device Status:     0x0000
   (Bus Powered)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
