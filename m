Subject: Re: broken VM in 2.4.10-pre9
References: <878A2048A35CD141AD5FC92C6B776E4907B7A5@xchgind02.nsisw.com>
From: "Bryan O'Sullivan" <bos@serpentine.com>
Date: 19 Sep 2001 15:51:45 -0700
In-Reply-To: <878A2048A35CD141AD5FC92C6B776E4907B7A5@xchgind02.nsisw.com>
Message-ID: <878zfaiyke.fsf@pelerin.serpentine.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rob Fuller <rfuller@nsisoftware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

r> I believe reverse mappings are an essential feature for memory
r> mapped files in order for Linux to support sophisticated
r> distributed file systems or distributed shared memory.

You already have the needed mechanisms for memory-mapped files in the
distributed FS case.  Distributed shared memory is much less
convincing, as DSM types have their heads irretrievably stuck up their
ar^Hcademia.

        <b
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
