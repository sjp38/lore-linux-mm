Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.30.0207181714420.30902-100000@divine.city.tvnet.hu>
References: <Pine.LNX.4.30.0207181714420.30902-100000@divine.city.tvnet.hu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 09:31:05 -0700
Message-Id: <1027009865.1555.105.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 08:22, Szakacsits Szabolcs wrote:

> Quickly looking through the patch I can't see what prevents total loss of
> control at constant memory pressure. For more please see:

I do not see anything in this email related to the issue at hand.

First, if the VM is broke that is an orthogonal issue that needs to be
fixed separately.

Specifically, what livelock situation are you insinuating?  If we only
allow allocation that are met by the backing store, we cannot get
anywhere near OOM.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
