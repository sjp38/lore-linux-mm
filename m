Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 406846B03AB
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 19:43:44 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g2so58464533qta.14
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 16:43:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 41si12970604qtg.277.2017.07.10.16.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 16:43:43 -0700 (PDT)
Date: Mon, 10 Jul 2017 19:43:39 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170710234339.GA15226@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <f04a007d-fc34-fe3a-d366-1363248a609f@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f04a007d-fc34-fe3a-d366-1363248a609f@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Mon, Jul 10, 2017 at 03:59:37PM -0700, Evgeny Baskakov wrote:
> On 6/30/17 5:57 PM, Jerome Glisse wrote:
> ...
> 
> Hi Jerome,
> 
> I am seeing a strange crash in our code that uses the hmm_device_new()
> helper. After the driver is repeatedly loaded/unloaded, hmm_device_new()
> suddenly returns NULL.
> 
> I have reproduced this with the dummy driver from the hmm-next branch:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000208

Horrible stupid bug in the code, most likely from cut and paste. Attached
patch should fix it. I don't know how long it took for you to trigger it.

Jerome

--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-mm-hmm-fix-major-device-driver-exhaustion-dumb-cut-a.patch"
Content-Transfer-Encoding: 8bit


--9jxsPFA5p3P2qPhR--
