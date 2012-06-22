Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5C8D06B005A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 16:23:11 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5026495pbb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 13:23:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120622201429.GM4642@google.com>
References: <20120619041154.GA28651@shangw>
	<20120619212059.GJ32733@google.com>
	<20120619212618.GK32733@google.com>
	<CAE9FiQVECyRBie-kgBETmqxPaMx24kUt1W07qAqoGD4vNus5xQ@mail.gmail.com>
	<20120621201728.GB4642@google.com>
	<CAE9FiQXubmnKHjnqOxVeoJknJZFNuStCcW=1XC6jLE7eznkTmg@mail.gmail.com>
	<20120622185113.GK4642@google.com>
	<CAE9FiQVV+WOWywnanrP7nX-wai=aXmQS1Dcvt4PxJg5XWynC+Q@mail.gmail.com>
	<20120622192919.GL4642@google.com>
	<CAE9FiQWcxEcuCjCSoAucvAOZ-6FCqRvjPoYc+JRmxdL50nyNxg@mail.gmail.com>
	<20120622201429.GM4642@google.com>
Date: Fri, 22 Jun 2012 13:23:10 -0700
Message-ID: <CAE9FiQXygFrvDzRScwgzsTT2_j7Xz2LbbBGSUKs5gwOv4Sd3Rw@mail.gmail.com>
Subject: Re: Early boot panic on machine with lots of memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jun 22, 2012 at 1:14 PM, Tejun Heo <tj@kernel.org> wrote:
>
> Alternatively, you can use mutt for patch sending / processing. =A0With
> caches turned on (set header_cache, set message_cachedir), it's
> actually pretty useable w/ gmail.

will try this.

i like to use gmail web client, and other way to send patch but keep
the threading.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
