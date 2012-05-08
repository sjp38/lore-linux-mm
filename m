Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 03D116B00F2
	for <linux-mm@kvack.org>; Tue,  8 May 2012 11:28:56 -0400 (EDT)
Date: Tue, 8 May 2012 16:31:44 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: mmap/clone returns ENOMEM with lots of free memory
Message-ID: <20120508163144.13ab1814@pyramind.ukuu.org.uk>
In-Reply-To: <alpine.DEB.2.00.1205080859570.25669@router.home>
References: <CAP145pjtv-S2oHhn8_QfLKF8APtut4B9qPXK5QM8nQbxzPd2gw@mail.gmail.com>
	<alpine.DEB.2.00.1205071514040.6029@router.home>
	<CAP145piK2kW4F94pNdKpo_sGg8OD914exOtwCx2o+83jx5Toog@mail.gmail.com>
	<alpine.DEB.2.00.1205080859570.25669@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Robert =?UTF-8?B?xZp3acSZY2tp?= <robert@swiecki.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> Setting overcommit memory to 2 means that the app is strictly policed
> for staying within bounds on virtual memory. Dont do that.

For a fuzz test you probably do want it at 2 to avoid the box dying in a
swap storm.


Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
