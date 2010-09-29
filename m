Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2C9686B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 09:40:19 -0400 (EDT)
Received: by gwj16 with SMTP id 16so380562gwj.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 06:40:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100929123752.GA18865@kroah.com>
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA1E338.6070201@redhat.com>
 <20100928151218.GJ14068@sgi.com> <20100929025035.GA13096@kroah.com>
 <4CA2F9A2.3090202@redhat.com> <20100929123752.GA18865@kroah.com>
From: Kay Sievers <kay.sievers@vrfy.org>
Date: Wed, 29 Sep 2010 15:39:58 +0200
Message-ID: <AANLkTi=uqVA5XGNKLg8=saXzWM5FA6KNP9fsAj80si_q@mail.gmail.com>
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory sections
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Avi Kivity <avi@redhat.com>, Robin Holt <holt@sgi.com>, Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 29, 2010 at 14:37, Greg KH <greg@kroah.com> wrote:
> On Wed, Sep 29, 2010 at 10:32:34AM +0200, Avi Kivity wrote:
>> =C2=A0On 09/29/2010 04:50 AM, Greg KH wrote:
>>> >
>>> > =C2=A0Because the old ABI creates 129,000+ entries inside
>>> > =C2=A0/sys/devices/system/memory with their associated links from
>>> > =C2=A0/sys/devices/system/node/node*/ back to those directory entries=
