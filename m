Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id BCA176B0032
	for <linux-mm@kvack.org>; Wed, 31 Dec 2014 10:47:39 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id k11so2541817wes.34
        for <linux-mm@kvack.org>; Wed, 31 Dec 2014 07:47:39 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0092.outbound.protection.outlook.com. [157.55.234.92])
        by mx.google.com with ESMTPS id hs6si84768760wjb.68.2014.12.31.07.47.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 Dec 2014 07:47:38 -0800 (PST)
Message-ID: <54A41A64.9080909@mellanox.com>
Date: Wed, 31 Dec 2014 17:46:44 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] HMM: introduce heterogeneous memory management.
References: <1419266940-5440-1-git-send-email-j.glisse@gmail.com>
 <1419266940-5440-4-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1419266940-5440-4-git-send-email-j.glisse@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul
 Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

Hi,

On 22/12/2014 18:48, j.glisse@gmail.com wrote:
> +/* hmm_device_register() - register a device with HMM.
> + *
> + * @device: The hmm_device struct.
> + * Returns: 0 on success or -EINVAL otherwise.
> + *
> + *
> + * Call when device driver want to register itself with HMM. Device driver can
> + * only register once. It will return a reference on the device thus to release
> + * a device the driver must unreference the device.

I see that the code doesn't actually have a reference count on the
hmm_device, but just registers and unregisters it through the
hmm_device_register/hmm_device_unregister functions. Perhaps you should
update the comment here to tell that.

> + */
> +int hmm_device_register(struct hmm_device *device)
> +{
> +	/* sanity check */
> +	BUG_ON(!device);
> +	BUG_ON(!device->name);
> +	BUG_ON(!device->ops);
> +	BUG_ON(!device->ops->release);
> +
> +	mutex_init(&device->mutex);
> +	INIT_LIST_HEAD(&device->mirrors);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(hmm_device_register);

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
