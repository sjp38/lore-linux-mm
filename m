Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id B65B58E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:21:50 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id v199so5619495vsc.21
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:21:50 -0800 (PST)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id s4si2453078uao.54.2019.01.18.03.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 03:21:49 -0800 (PST)
Date: Fri, 18 Jan 2019 11:21:34 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs
 attributes
Message-ID: <20190118112134.00003b65@huawei.com>
In-Reply-To: <20190116175804.30196-6-keith.busch@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
	<20190116175804.30196-6-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 16 Jan 2019 10:57:56 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Add entries for memory initiator and target node class attributes.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
>  1 file changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 3e90e1f3bf0a..a9c47b4b0eee 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -90,4 +90,27 @@ Date:		December 2009
>  Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>  		The node's huge page size control/query attributes.
> -		See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +		See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:		/sys/devices/system/node/nodeX/classY/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node's relationship to other nodes for access class "Y".
> +
> +What:		/sys/devices/system/node/nodeX/classY/initiator_nodelist
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node list of memory initiators that have class "Y" access
> +		to this node's memory. CPUs and other memory initiators in
> +		nodes not in the list accessing this node's memory may have
> +		different performance.
> +
> +What:		/sys/devices/system/node/nodeX/classY/target_nodelist
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node list of memory targets that this initiator node has
> +		class "Y" access. Memory accesses from this node to nodes not
> +		in this list may have differet performance.

Different performance from what?  In the other thread we established that
these target_nodelists are kind of a backwards reference, they all have
their characteristics anyway.  Perhaps this just needs to say:
"Memory access from this node to these targets may have different performance"?

i.e. Don't make the assumption I did that they should all be the same!
