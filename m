Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7A6A8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:56:58 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e88-v6so2381qtb.1
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:56:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x59-v6si2925539qte.381.2018.09.11.15.56.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 15:56:58 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <28a55df5da1ecfea28bac588d3ac429cf1419b42.1536356108.git.alison.schofield@intel.com>
References: <28a55df5da1ecfea28bac588d3ac429cf1419b42.1536356108.git.alison.schofield@intel.com> <cover.1536356108.git.alison.schofield@intel.com>
Subject: Re: [RFC 04/12] x86/mm: Add helper functions to manage memory encryption keys
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <30750.1536706615.1@warthog.procyon.org.uk>
Date: Tue, 11 Sep 2018 23:56:55 +0100
Message-ID: <30751.1536706615@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Alison Schofield <alison.schofield@intel.com> wrote:

> +void mktme_map_set_keyid(int keyid, unsigned int serial)
> +{
> +	mktme_map->serial[keyid] = serial;
> +	mktme_map->mapped_keyids++;
> +}

It appears that 'serial' should be key_serial_t.

Note that you *aren't* allowed to cache key serial numbers inside the kernel.
You must cache the struct key * instead and hold a reference to the key.  This
will prevent the key from being destroyed whilst it is in use.

David
